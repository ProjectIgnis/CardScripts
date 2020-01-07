--融合呪印生物－地
local s,id=GetID()
function s.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(0)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--fusion substitute
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e2:SetCondition(s.subcon)
	c:RegisterEffect(e2)
end
function s.subcon(e)
	return e:GetHandler():IsLocation(0x1e)
end
function s.filter(c,e,tp,m,gc,chkf)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_EARTH)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.fil(c,tp)
	return c:IsCanBeFusionMaterial() and c:IsHasEffect(59160188)
end
function s.fcheck(mg)
	return function(tp,sg,fc)
		return #sg-#(sg-mg)<2
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local chkf=tp|FUSPROC_NOTFUSION
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		local mg=Duel.GetMatchingGroup(Card.IsCanBeFusionMaterial,tp,LOCATION_MZONE,0,nil)
		local mg2=Duel.GetMatchingGroup(s.fil,tp,0,LOCATION_MZONE,nil,tp)
		Fusion.CheckAdditional=s.fcheck(mg2)
		local res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg+mg2,c,chkf)
		Fusion.CheckAdditional=nil
		return res
	end
	local mg=Duel.GetMatchingGroup(Card.IsCanBeFusionMaterial,tp,LOCATION_MZONE,0,nil)
	local mg2=Duel.GetMatchingGroup(s.fil,tp,0,LOCATION_MZONE,nil,tp)
	Fusion.CheckAdditional=s.fcheck(mg2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg+mg2,c,chkf)
	local mat=Duel.SelectFusionMaterial(tp,g:GetFirst(),mg+mg2,c,chkf)
	Fusion.CheckAdditional=nil
	if #(mat-mg2)~=#mat then
		local fc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
		Duel.Hint(HINT_CARD,0,fc:GetCode())
		fc:RegisterFlagEffect(59160188,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	end
	Duel.Release(mat,REASON_COST)
	e:SetLabel(g:GetFirst():GetCode())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.filter2(c,e,tp,code)
	return c:IsCode(code) and Duel.GetLocationCountFromEx(tp,tp,nil,c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	local tc=Duel.GetFirstMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,code)
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
