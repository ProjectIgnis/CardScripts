--パルマ・ライゼオル
--Palm Ryzeal
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Special Summon this card (from your hand)
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	--You cannot Special Summon from the Extra Deck, except Rank 4 Xyz Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not (c:IsType(TYPE_XYZ) and c:IsRank(4)) end)
	c:RegisterEffect(e1)
	aux.addContinuousLizardCheck(c,LOCATION_MZONE,function(e,c) return not (c:IsOriginalType(TYPE_XYZ) and c:IsOriginalRank(4)) end)
	--Send 1 Level 4 monster from your hand/Deck to the GY and this card gains ATK equal to that monster's, until the end of the Battle Phase
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_RYZEAL}
function s.spconfilter(c)
	return c:IsSetCard(SET_RYZEAL) and c:IsMonster() and c:IsAbleToDeckOrExtraAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local rg=Duel.GetMatchingGroup(s.spconfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,c)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,nil,1,tp,HINTMSG_TODECK,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
	else
		Duel.HintSelection(g)
	end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	g:DeleteGroup()
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return bc and bc:IsControler(1-tp)
end
function s.tgfilter(c)
	return c:IsLevel(4) and c:IsAbleToGrave()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil):GetFirst()
	if sc and Duel.SendtoGrave(sc,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_GRAVE) and sc:GetAttack()>0
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		--Gains ATK equal to the ATK of the monster sent to the GY until the end of the Battle Phase
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(sc:GetAttack())
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_BATTLE)
		c:RegisterEffect(e1)
	end
end