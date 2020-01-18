--ピンポイント奪取
--Pinpoint Dash
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_EXTRA,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_EXTRA,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g0=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_EXTRA,0,nil)
	local g1=Duel.GetMatchingGroup(Card.IsFacedown,1-tp,LOCATION_EXTRA,0,nil)
	if #g0==0 or #g1==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local tc0=g0:Select(tp,1,1,nil):GetFirst()
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
	local tc1=g1:Select(1-tp,1,1,nil):GetFirst()
	Duel.ConfirmCards(1-tp,tc0)
	Duel.ConfirmCards(tp,tc1)
	if s.compare(tc0,tc1) then
		if Duel.SendtoGrave(tc1,REASON_EFFECT)~=0 and Duel.GetLocationCountFromEx(tp,tp,tc0)>0
			and Duel.SpecialSummon(tc0,0,tp,tp,false,false,POS_FACEUP)~=0
			and tc0:GetOriginalRace()==tc1:GetOriginalRace()
			and tc0:GetOriginalAttribute()==tc1:GetOriginalAttribute() then
			local diff=math.max(tc1:GetAttack(),0)
			if diff>0 then
				Duel.SetLP(1-tp,Duel.GetLP(1-tp)-diff)
			end
		end
	else
		if Duel.SendtoGrave(tc0,REASON_EFFECT)~=0 and Duel.GetLocationCountFromEx(1-tp,1-tp,tc1)>0 then
			Duel.SpecialSummon(tc1,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
end
function s.compare(c1,c2)
	local tps={TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ,TYPE_LINK}
	for i,tp in ipairs(tps) do
		if c1:IsType(tp) and c2:IsType(tp) then return true end
	end
	return false
end

