--玄翼竜 ブラック・フェザー
--Blackfeather Darkrage Dragon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Send up to 5 cards from the top of your Deck to the GY, then if any monsters were sent to the GY by this effect, this card gains 400 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==tp end)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function s.monfilter(c)
	return c:IsMonster() and c:IsLocation(LOCATION_GRAVE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	local c=e:GetHandler()
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct>5 then ct=5 end
	local ac=ct==1 and 1 or Duel.AnnounceNumberRange(tp,1,ct)
	if Duel.DiscardDeck(tp,ac,REASON_EFFECT)==0 then return end
	local og=Duel.GetOperatedGroup()
	if og:IsExists(s.monfilter,1,nil) and c:IsFaceup() and c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		--This card gains 400 ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end