--Dream Mirror of Chaos
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)    
    if not GhostBelleTable then GhostBelleTable={} end
    table.insert(GhostBelleTable,e1)
end
s.listed_series={0x131}
s.listed_names={CARD_DREAM_MIRROR_JOY,CARD_DREAM_MIRROR_TERROR }
function s.filter0(c,e)
    return c:IsCanBeFusionMaterial() and c:IsType(TYPE_MONSTER)
end
function s.exfilter0(c)
    return c:IsCanBeFusionMaterial() and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove() and aux.SpElimFilter(c)
end
function s.exfilter1(c,e)
    return c:IsCanBeFusionMaterial() and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()  and aux.SpElimFilter(c) and not c:IsImmuneToEffect(e)
end
function s.filter1(c,e)
    return c:IsCanBeFusionMaterial() and c:IsType(TYPE_MONSTER) and not c:IsImmuneToEffect(e)
end
function s.filter2(c,e,tp,m,f,chkf)
    return c:IsSetCard(0x131) and c:IsType(TYPE_FUSION) and (not f or f(c))
        and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local chkf=tp
        local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
        if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,CARD_DREAM_MIRROR_JOY),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) then
            mg1:Merge(Duel.GetMatchingGroup(s.filter0,tp,LOCATION_HAND,0,nil,e))
        end
        if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,CARD_DREAM_MIRROR_TERROR),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) then
            mg1:Merge(Duel.GetMatchingGroup(s.exfilter0,tp,LOCATION_GRAVE,0,nil,e))
        end
        local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
        if not res then
            local ce=Duel.GetChainMaterial(tp)
            if ce~=nil then
                local fgroup=ce:GetTarget()
                local mg2=fgroup(ce,e,tp)
                local mf=ce:GetValue()
                res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
            end
        end
        return res
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local chkf=tp
    local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e):Filter(Card.IsOnField,nil)
    if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,CARD_DREAM_MIRROR_JOY),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) then
		mg1:Merge(Duel.GetMatchingGroup(s.filter1,tp,LOCATION_HAND,0,nil,e))
    end
    if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,CARD_DREAM_MIRROR_TERROR),tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) then
		mg1:Merge(Duel.GetMatchingGroup(s.exfilter1,tp,LOCATION_GRAVE,0,nil,e))
    end
    local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
    local mg2=nil
    local sg2=nil
    local ce=Duel.GetChainMaterial(tp)
    if ce~=nil then
        local fgroup=ce:GetTarget()
        mg2=fgroup(ce,e,tp)
        local mf=ce:GetValue()
        sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
    end
    if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
        local sg=sg1:Clone()
        if sg2 then sg:Merge(sg2) end
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
        local tg=sg:Select(tp,1,1,nil)
        local tc=tg:GetFirst()
        if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
            local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
            tc:SetMaterial(mat1)
            local mat2=mat1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
            mat1:Sub(mat2)
            Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
            Duel.Remove(mat2,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
            Duel.BreakEffect()
            Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
        else
            local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
            local fop=ce:GetOperation()
            fop(ce,e,tp,tc,mat2)
        end
        tc:CompleteProcedure()
    end
end

