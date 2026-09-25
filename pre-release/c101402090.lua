--JP Name
--Angelechy Castellan
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1+ non-Tuners
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--You can target 1 opponent's monster in this card's adjacent column, or 1 card in your opponent's Spell & Trap Zone that is 2 columns away from this card's; banish that card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.bantg)
	e1:SetOperation(s.banop)
	c:RegisterEffect(e1)
	--If this card is placed in the Spell & Trap Zone as a Continuous Spell: You can send 1 "Angelechy" card from your Deck to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_MOVE)
	e2:SetRange(LOCATION_STZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	--While this card is treated as a Continuous Spell, each player can only activate 1 card or effect per Chain
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3a:SetCode(EVENT_CHAINING)
	e3a:SetRange(LOCATION_STZONE)
	e3a:SetCondition(function(e)
		return e:GetHandler():IsContinuousSpell()
	end)
	e3a:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		e:GetHandler():RegisterFlagEffect(id+(ep*100),RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
	end)
	c:RegisterEffect(e3a)
	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_FIELD)
	e3b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3b:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3b:SetRange(LOCATION_STZONE)
	e3b:SetTargetRange(1,1)
	e3b:SetCondition(function(e)
		return e:GetHandler():IsContinuousSpell()
	end)
	e3b:SetValue(function(e,re,rp)
		return e:GetHandler():HasFlagEffect(id+(rp*100))
	end)
	c:RegisterEffect(e3b)
end
s.listed_series={SET_ANGELECHY}
function s.normalizeseq(seq)
	if seq==5 then return 1 end
	if seq==6 then return 3 end
	return seq
end
function s.banfilter(c,seq)
	if not c:IsAbleToRemove() then return false end
	local dist=math.abs(seq-s.normalizeseq(c:GetSequence()))
	if c:IsLocation(LOCATION_MZONE) then return dist==1 end
	return dist==2
end
function s.bantg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local seq=4-s.normalizeseq(e:GetHandler():GetSequence())
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE|LOCATION_STZONE) and s.banfilter(chkc,seq) end
	if chk==0 then return Duel.IsExistingTarget(s.banfilter,tp,0,LOCATION_MZONE|LOCATION_STZONE,1,nil,seq) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.banfilter,tp,0,LOCATION_MZONE|LOCATION_STZONE,1,1,nil,seq)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
end
function s.banop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return eg:IsContains(c) and not c:IsPreviousLocation(LOCATION_SZONE)
end
function s.tgfilter(c)
	return c:IsSetCard(SET_ANGELECHY) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end