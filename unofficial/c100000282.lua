--玄翼竜 ブラック・フェザー (Manga)
--Blackfeather Darkrage Dragon (Manga)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1 or more non-Tuner monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Send 1 card from your Deck to the GY for every for 400 points of damage inflicted
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return (r&REASON_EFFECT)>0 end)
	e1:SetTarget(s.deckdestg)
	e1:SetOperation(s.deckdesop)
	c:RegisterEffect(e1)
end
function s.deckdestg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return ev>=400 and Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,0)
end
function s.deckdesop(e,tp,eg,ep,ev,re,r,rp)
	local ct=math.floor(ev/400)
	Duel.DiscardDeck(tp,ct,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	local ct=g:FilterCount(Card.IsMonster,nil)
	if ct==0 then return end
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*400)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end