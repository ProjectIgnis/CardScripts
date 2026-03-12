--三幻魔の失楽園
--Fallen Paradise of the Sacred Beasts
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Thrice per turn: You can send 3 other cards of the same type (Monster, Spell, or Trap) from your hand and/or face-up field to the GY, then you can Special Summon 1 "Sacred Beast" monster from your hand, Deck, GY, or banishment, and if you do, it is unaffected by your opponent's activated Spell/Trap effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(3)
	e1:SetTarget(s.gytg)
	e1:SetOperation(s.gyop)
	c:RegisterEffect(e1)
	--If you control a "Sacred Beast" monster whose original Level is 10: You can draw 2 cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SACRED_BEAST}
function s.gyfilter(c)
	return c:IsAbleToGrave() and (c:IsFaceup() or not c:IsOnField())
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetMainCardType)==1
end
local LOCATIONS_HAND_DECK_GRAVE_REMOVED=LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,e:GetHandler())
		return aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,3,tp,LOCATION_HAND|LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATIONS_HAND_DECK_GRAVE_REMOVED)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_SACRED_BEAST) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.gyfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,c)
	if #g<3 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_TOGRAVE)
	if #sg==3 and Duel.SendtoGrave(sg,REASON_EFFECT)==3 and sg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATIONS_HAND_DECK_GRAVE_REMOVED,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATIONS_HAND_DECK_GRAVE_REMOVED,0,1,1,nil,e,tp):GetFirst()
		if not sc then return end
		Duel.BreakEffect()
		if Duel.SpecialSummonStep(sc,0,tp,tp,false,true,POS_FACEUP) then
			--It is unaffected by your opponent's activated Spell/Trap effects
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,3))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetValue(function(e,te) return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated() and te:IsSpellTrapEffect() end)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			sc:RegisterEffect(e1)
		end
		Duel.SpecialSummonComplete()
	end
end
function s.drconfilter(c)
	return c:IsSetCard(SET_SACRED_BEAST) and c:IsOriginalLevel(10) and c:IsFaceup()
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.drconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end