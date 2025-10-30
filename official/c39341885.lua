--絢嵐たる海霊ヴァルルーン
--Radiant Typhoon Varuroon, the Sea Spirit
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2 "Radiant Typhoon" monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_RADIANT_TYPHOON),2)
	--Add 1 "Mystical Space Typhoon" from your Deck or GY to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Place 2 face-up monsters on the field, including a "Radiant Typhoon" monster you control face-up in their owners' Spell & Trap Zones as Continuous Spells
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.monpltg)
	e2:SetOperation(s.monplop)
	c:RegisterEffect(e2)
	--Place 1 "Radiant Typhoon" Continuous Trap from your Deck or GY face-up on your field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsSpellEffect() and re:IsActiveType(TYPE_QUICKPLAY) end)
	e3:SetTarget(s.trappltg)
	e3:SetOperation(s.trapplop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_RADIANT_TYPHOON}
s.listed_names={CARD_MYSTICAL_SPACE_TYPHOON}
function s.thfilter(c)
	return c:IsCode(CARD_MYSTICAL_SPACE_TYPHOON) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.monplfilter(c,e)
	return c:IsFaceup() and not c:IsForbidden() and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp)
	local your_g,opp_g=sg:Split(Card.IsOwner,nil,tp)
	return #sg==2 and #your_g>0 and your_g:IsExists(Card.IsSetCard,1,nil,SET_RADIANT_TYPHOON)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>=#your_g
		and Duel.GetLocationCount(1-tp,LOCATION_SZONE)>=#opp_g
end
function s.monpltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.monplfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOFIELD)
	Duel.SetTargetCard(tg)
end
function s.monplop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetTargetCards(e)
	for tc in tg:Iter() do
		if not tc:IsImmuneToEffect(e) then
			local owner=tc:GetOwner()
			if Duel.GetLocationCount(owner,LOCATION_SZONE)<=0 then
				Duel.SendtoGrave(tc,REASON_RULE,nil,PLAYER_NONE)
			elseif Duel.MoveToField(tc,tp,owner,LOCATION_SZONE,POS_FACEUP,tc:IsMonsterCard()) then
				--Treated as a Continuous Spell
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_CHANGE_TYPE)
				e1:SetValue(TYPE_SPELL|TYPE_CONTINUOUS)
				e1:SetReset(RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET))
				tc:RegisterEffect(e1)
			end
		end
	end
end
function s.trapplfilter(c,tp)
	return c:IsSetCard(SET_RADIANT_TYPHOON) and c:IsContinuousTrap() and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.trappltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 
		and Duel.IsExistingMatchingCard(s.trapplfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tp) end
end
function s.trapplop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.trapplfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if sc then 
		Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end