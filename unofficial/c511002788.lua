--Quiz Panel - Ra 30
os = require('os')
local s,id=GetID()
function s.initial_effect(c)
	--flip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51102781,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c,g)
	return g:IsExists(Card.IsCode,1,nil,c:GetCode())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local endtime=0
	local check=true
	local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_DECK,0,1,3,nil)
	local ct=Duel.GetMatchingGroupCount(s.filter,tp,0x13,0,nil,g)
	local start=os.time()
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(4006,8))
	local tc=Duel.AnnounceNumber(1-tp,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,
		44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,
		93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120)
	endtime=os.time()-start
	check=endtime<=10 and tc==ct
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
	if check then
		Duel.Damage(tp,1200,REASON_EFFECT)
	else
		local a=Duel.GetAttacker()
		if a and a:IsRelateToBattle() then
			Duel.Destroy(a,REASON_EFFECT)
		end
		Duel.Damage(1-tp,1200,REASON_EFFECT)
	end
end
