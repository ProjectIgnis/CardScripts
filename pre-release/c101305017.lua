--人工神霊ヴィラカム
--Virakam the Artificial Spirit
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--If you have an "Aleister" monster in your field or GY: You can Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If this card is Special Summoned: You can Set 1 "Invocation", or 1 Spell that mentions it, from your Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	--When your opponent activates a card or effect in response to the activation of your Fusion Monster's effect (Quick Effect): You can banish this card from the field, and if you do, negate that opponent's effect, and if you do that, banish that card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_INVOCATION}
s.listed_series={SET_ALEISTER}
function s.spconfilter(c)
	return c:IsSetCard(SET_ALEISTER) and c:IsMonster() and c:IsFaceup()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.setfilter(c)
	return (c:IsCode(CARD_INVOCATION) or (c:IsSpell() and c:ListsCode(CARD_INVOCATION))) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_DECK)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local chainlink=Duel.GetCurrentChain(true)-1
	if not (chainlink>0 and Duel.IsChainDisablable(ev) and ep==1-tp) then return false end
	local trig_player,trig_type=Duel.GetChainInfo(chainlink,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_TYPE)
	return trig_player==tp and (trig_type&TYPE_FUSION)>0
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	local relation=rc:IsRelateToEffect(re)
	if chk==0 then return c:IsAbleToRemove() and (rc:IsAbleToRemove(tp)
		or (not relation and Duel.IsPlayerCanRemove(tp))) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0)
	if relation then
		rc:CreateEffectRelation(e)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,Group.FromCards(c,rc),1,tp,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,c,1,tp,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,rc:GetPreviousControler(),rc:GetPreviousLocation())
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Remove(c,nil,REASON_EFFECT)>0 and c:IsLocation(LOCATION_REMOVED)
		and Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end