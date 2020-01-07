--Re-Xyz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.rescon(pg)
	return	function(sg,e,tp,mg)
				return sg:Includes(pg) and sg:GetClassCount(Card.GetLevel)==1
			end
end
function s.filter(c,e,tp,g,pg)
	local ct=c.minxyzct
	local sg=g:Clone()
	sg:RemoveCard(c)
	return ct and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,true) and c:IsType(TYPE_XYZ)
		and aux.SelectUnselectGroup(sg,e,tp,ct,ct,s.rescon(pg),0)
end
function s.matfilter(c,e)
	return c:GetLevel()>0 and c:IsCanBeEffectTarget(e)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_GRAVE,0,nil,e)
	local pg=aux.GetMustBeMaterialGroup(tp,g,tp,nil,nil,REASON_XYZ)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,g,pg) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,g,pg):GetFirst()
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,0)
	local ct=tc.minxyzct
	local ct2=tc.maxxyzct
	g:RemoveCard(tc)
	local sg=aux.SelectUnselectGroup(g,e,tp,ct,ct2,s.rescon(pg),1,tp,HINTMSG_XMATERIAL,s.rescon(pg))
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	local sg=g:Filter(aux.FilterEqualFunction(Card.GetFlagEffect,0,id),nil)
	local tc=g:Filter(aux.TRUE,sg):GetFirst()
	local pg=aux.GetMustBeMaterialGroup(tp,g,tp,nil,nil,REASON_XYZ)
	if tc and tc:IsRelateToEffect(e) and #sg>0 and sg:Includes(pg) then
		tc:SetMaterial(sg)
		Duel.Overlay(tc,sg)
		Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
