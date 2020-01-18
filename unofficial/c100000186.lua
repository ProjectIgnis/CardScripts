--スフィア・フィールド
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--XYZ
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_series={0x48}
function s.filter(c,e)
	return c:IsType(TYPE_MONSTER) and (not e or not c:IsImmuneToEffect(e))
end
function s.lvfilter(c,g)
	return g:IsExists(aux.FilterBoolFunction(Card.IsLevel,c:GetLevel()),1,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil)
		local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_XYZ)
		return #pg<=0 and Duel.GetLocationCountFromEx(tp)>0 and g:IsExists(s.lvfilter,1,nil,g) 
			and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzfilter(c,e,tp)
	return c:IsSetCard(0x48) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,true,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local pg=aux.GetMustBeMaterialGroup(tp,Group.CreateGroup(),tp,nil,nil,REASON_XYZ)
	if not e:GetHandler():IsRelateToEffect(e) or Duel.GetLocationCountFromEx(tp)<=0 or #pg>0 then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil,e)
	local sg=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if #sg>0 and g:IsExists(s.lvfilter,1,nil,g) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local mg1=g:FilterSelect(tp,s.lvfilter,1,1,nil,g)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
		local mg2=g:FilterSelect(tp,aux.FilterBoolFunction(Card.IsLevel,mg1:GetFirst():GetLevel()),1,1,mg1)
		mg1:Merge(mg2)
		local xyz=sg:RandomSelect(tp,1):GetFirst()
		if Duel.SpecialSummonStep(xyz,SUMMON_TYPE_XYZ,tp,tp,true,false,POS_FACEUP) then
			--destroy
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SELF_DESTROY)
			e1:SetCondition(s.descon)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			xyz:RegisterEffect(e1)
			end
			Duel.Overlay(xyz,mg1)
			Duel.SpecialSummonComplete()
			xyz:CompleteProcedure()
	end
end
function s.descon(e)
	return e:GetHandler():GetOverlayCount()==0 and Duel.GetCurrentChain()==0
end
