--Decisive Power of Absolute Destiny
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummon(1-tp) 
		and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_DECK,1,nil) end
	s.announce_filter={TYPE_MONSTER,OPCODE_ISTYPE}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
end
function s.filter(c,code,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummon(1-tp) then return end
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(1-tp,s.filter,1-tp,LOCATION_DECK,0,1,1,nil,ac,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,1-tp,1-tp,false,false,POS_FACEUP_ATTACK)
	end
end
