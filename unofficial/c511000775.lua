--Blackwing - Delta Union
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x33}
function s.spfilter(c,e,tp,tid)
	return c:IsSetCard(0x33) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetTurnID()==tid and c:IsReason(REASON_DESTROY)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x33)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tid=Duel.GetTurnCount()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp,tid)
	local sg=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 and (#g>1 or #sg>0)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>=#g and Duel.GetLocationCount(tp,LOCATION_SZONE)>=#g+#sg-1 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,nil,#sg+#g-1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tid=Duel.GetTurnCount()
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp,tid)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<#g then return end
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local sg=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_MZONE,0,nil)
		if #sg>1 and Duel.GetLocationCount(tp,LOCATION_SZONE)>=#sg-1 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
			local ec=sg:Select(tp,1,1,nil):GetFirst()
			sg:RemoveCard(ec)
			sg:ForEach(function(tc)
				Duel.Equip(tp,tc,ec,false,true)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(s.eqlimit)
				e1:SetLabelObject(ec)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_EQUIP)
				e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e2:SetCode(EFFECT_UPDATE_ATTACK)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				e2:SetValue(500)
				tc:RegisterEffect(e2)
			end)
			Duel.EquipComplete()
		end
	end
end
function s.eqlimit(e,c)
	return e:GetLabelObject()==c
end
