--超魔剣士ブラック・カオス
--Black Chaos the Ultimate Magical Swordsman
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:AddMustBeSpecialSummoned()
	--Must be Special Summoned (from your hand) by shuffling 1 Spellcaster or Warrior Ritual Monster from your hand or GY into the Deck
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e0:SetCondition(s.spcon)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	c:RegisterEffect(e0)
	--You can discard this card; place 1 Continuous Trap that mentions "Ritual of Light and Darkness" from your Deck or GY, face-up on your field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
	--Unaffected by your opponent's activated effects while you have a Ritual Spell in your GY
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e) return Duel.IsExistingMatchingCard(Card.IsRitualSpell,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil) end)
	e2:SetValue(function(e,te) return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated() end)
	c:RegisterEffect(e2)
	--Once per turn: You can banish 2 cards your opponent controls
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_RITUAL_OF_LIGHT_AND_DARKNESS}
function s.spconfilter(c)
	return c:IsRace(RACE_SPELLCASTER|RACE_WARRIOR) and c:IsRitualMonster() and c:IsAbleToDeckAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.spconfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,1,nil,1,tp,HINTMSG_TODECK,nil,nil,true)
	if #sg>0 then
		e:SetLabelObject(sg)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if g then
		local sc=g:GetFirst()
		if sc:IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,sc)
		else
			Duel.HintSelection(sc)
		end
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	end
end
function s.plfilter(c,tp)
	return c:IsContinuousTrap() and c:ListsCode(CARD_RITUAL_OF_LIGHT_AND_DARKNESS) and not c:IsForbidden() and c:CheckUniqueOnField(tp) 
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tp) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.plfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	if sc then
		Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,1-tp,LOCATION_ONFIELD)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,2,2,nil)
	if #g==2 then
		Duel.HintSelection(g)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end