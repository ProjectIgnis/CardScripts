--英雄の掛橋－ビヴロスト (Anime)
--Rainbow Bridge Bifrost (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_VALKYRIE}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_VALKYRIE),tp,LOCATION_MZONE,0,1,nil) 
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsMonster),tp,0,LOCATION_REMOVED,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_VALKYRIE),tp,LOCATION_MZONE,0,nil)
	local rg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsMonster),tp,0,LOCATION_REMOVED,nil)
	if #mg==0 or #rg==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local sg=mg:Select(tp,1,1,nil)
	local tc=sg:GetFirst()
	if tc and tc:IsFaceup() then
		Duel.HintSelection(tc)
		tc:UpdateAttack(#rg*500,RESETS_STANDARD_PHASE_END,c)
	end
end
