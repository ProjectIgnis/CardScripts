--相の魔導兵
--Triad Proteus
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2 Effect Monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2)
	--If this card is Special Summoned: You can discard 1 card; this card gains this effect based on the discarded card's type (Monster, Spell, Trap).
	--● Monster: Gains 800 ATK.
	--● Spell: If a monster(s) you control would be destroyed by card effect, you can destroy this card instead.
	--● Trap: Once per turn, if a monster(s) is Special Summoned to a zone(s) this card points to: You can destroy all monsters this card points to.
	--You can only use this effect of "Triad Proteus" once per turn.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.Discard())
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.efffop)
	c:RegisterEffect(e1)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if (e:GetChainData().cost_discarded_cards:GetFirst():GetMainCardType())==TYPE_MONSTER then
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,800)
	end
end
function s.efffop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local string_index=nil
	local cost_card=e:GetChainData().cost_discarded_cards:GetFirst()
	local typ=cost_card:GetMainCardType()
	if typ==TYPE_MONSTER then
		string_index=1
		--● Monster: Gains 800 ATK
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	elseif typ==TYPE_SPELL then
		string_index=2
		--● Spell: If a monster(s) you control would be destroyed by card effect, you can destroy this card instead
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EFFECT_DESTROY_REPLACE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTarget(s.replacementg)
		e2:SetValue(s.replacementvalue)
		e2:SetOperation(s.replacementop)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e2)
	elseif typ==TYPE_TRAP then
		string_index=3
		--● Trap: Once per turn, if a monster(s) is Special Summoned to a zone(s) this card points to: You can destroy all monsters this card points to
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,4))
		e3:SetCategory(CATEGORY_DESTROY)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e3:SetProperty(EFFECT_FLAG_DELAY)
		e3:SetCode(EVENT_SPSUMMON_SUCCESS)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCountLimit(1)
		e3:SetCondition(aux.zptcon(nil))
		e3:SetTarget(s.destg)
		e3:SetOperation(s.desop)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e3)
	end
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,string_index))
end
function s.replacementfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE) 
end
function s.replacementg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.replacementfilter,1,c,tp)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.replacementvalue(e,c)
	return s.replacementfilter(c,e:GetHandlerPlayer())
end
function s.replacementop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT|REASON_REPLACE)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local linked_group=e:GetHandler():GetLinkedGroup():Match(Card.IsMonster,nil)
	if chk==0 then return #linked_group>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,linked_group,#linked_group,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local linked_group=c:GetLinkedGroup():Match(Card.IsMonster,nil)
	if c:IsRelateToEffect(e) and #linked_group>0 then
		Duel.Destroy(linked_group,REASON_EFFECT)
	end
end