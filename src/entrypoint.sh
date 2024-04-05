stages=${*:-1 2 3}


# start sonarqube server and wait for it to come up
if grep -q 1 <<<"$stages" ; then
    sudo service jenkins start
    cat /var/log/jenkins/jenkins.log
fi

# setup scanner
if grep -q 2 <<<"$stages" ; then
    bash /opt/sonarscan.sh setup
fi

# setup scanner and run scans
if grep -q 3 <<<"$stages" ; then
    bash /opt/sonarscan.sh \
        "/PG&E/workflow_oa/logic/workflow_oa_repository" \
        "/PG&E/workflow_oa/logic/OA-TCM Sub-Models Repo" \
        "/PG&E/ontology_electric_transmission/public/logic/ontology_electric_transmission_repository" \
        "/PG&E/workflow_et_composite_risk_model/logic/TCM Input Cleaning" \
        "/PG&E/ontology_electric_transmission/product/logic/ontology_electric_transmission_oa_repository" \
        "/PG&E/transform_electric_transmission/logic/transform_electric_transmission_repository" \
        "/PG&E/datasource_meteorology_database/logic/meteorology_database_repository" \
        "/PG&E/datasource_etgis/logic/datasource_etgis_repository" \
        "/PG&E/datasource_lbgis/logic/datasource_lbgis_repository" \
        "/PG&E/transform_pronto/logic/transform_pronto_repository" \
        transform_sap_repository="/PG&E/transform_sap/logic/sap_repository" \
        "/PG&E/datasource_data_dumps_afa_gdat/data_cleaning" \
        "/PG&E/transform_eo_work_management/logic/transform_eo_work_management_repository" \
        "/PG&E/workflow_data_dumps_oa/logic/workflow_data_dumps_oa_repository" \
        "/PG&E/datasource_pronto/logic/datasource_pronto_repository" \
        "/PG&E/transform_assets/logic/transform_assets_repository" \
        "/PG&E/datasource_arcgis/logic/arcgis_repository" \
        "/Datasource/datasource_eo_work_management/logic/datasource_eo_work_management_repository" \
        datasource_sap_repository="/PG&E/datasource_sap/logic/sap_repository"      
fi
