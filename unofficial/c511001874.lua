--レスキュー・エクシーズ
--Xyz Rescue
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon using monsters you own controlled by the opponent
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:GetOwner()~=c:GetControler()
end
function s.xyzfilter(c,tp,mg)
	return c:IsXyzSummonable(nil,mg) and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
function s.registerxyzmateffect(e,tp)
	local matEff=Effect.CreateEffect(e:GetHandler())
	matEff:SetType(EFFECT_TYPE_FIELD)
	matEff:SetCode(EFFECT_XYZ_MATERIAL)
	matEff:SetTargetRange(0,LOCATION_MZONE)
	matEff:SetTarget(aux.TargetBoolFunction(s.filter))
	Duel.RegisterEffect(matEff,tp)
	return matEff
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
		local matEff=s.registerxyzmateffect(e,tp)
		local res=Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,tp,mg)
		matEff:Reset()
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	local matEff=s.registerxyzmateffect(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local xyz=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp,mg):GetFirst()
	if xyz then
		Duel.XyzSummon(tp,xyz,nil,mg)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SPSUMMON_COST)
		e1:SetOperation(function()
			matEff:Reset()
		end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		xyz:RegisterEffect(e1,true)
	else
		matEff:Reset()
	end
end