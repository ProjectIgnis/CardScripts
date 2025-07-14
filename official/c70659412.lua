--
--Psychic Omnibuster
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + 1+ non-Tuner Psychic monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsRace,RACE_PSYCHIC),1,99)
	--Look at 1 random card in your opponent's hand, and if it is the declared card type, apply these effects in sequence
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e,tp,eg,ep,ev) return ep==1-tp and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)&(LOCATION_MZONE|LOCATION_SZONE)>0 end)
	e1:SetCost(Cost.PayLP(2000))
	e1:SetTarget(s.looktg)
	e1:SetOperation(s.lookop)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		s.declared_types={}
		s.declared_types[0]=0
		s.declared_types[1]=0
		aux.AddValuesReset(function()
			s.declared_types[0]=0
			s.declared_types[1]=0
		end)
	end)
end
function s.looktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local declared_types=s.declared_types[tp]
	if chk==0 then return declared_types~=(TYPE_MONSTER|TYPE_SPELL|TYPE_TRAP) and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	local op=Duel.SelectEffect(tp,
		{declared_types&TYPE_MONSTER==0,DECLTYPE_MONSTER},
		{declared_types&TYPE_SPELL==0,DECLTYPE_SPELL},
		{declared_types&TYPE_TRAP==0,DECLTYPE_TRAP})
	local typ=1<<(op-1)
	s.declared_types[tp]=declared_types|typ
	Duel.SetTargetParam(typ)
end
function s.lookop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)==0 then return end
	local rc=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,1):GetFirst()
	Duel.ConfirmCards(tp,rc)
	Duel.ShuffleHand(1-tp)
	local typ=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if not rc:IsType(typ) then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local desc=(typ==TYPE_MONSTER and 3010)
			or (typ==TYPE_SPELL and 3011)
			or (typ==TYPE_TRAP and 3012)
		Duel.BreakEffect()
		--This card cannot be destroyed by the effects of the declared card type this turn
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(desc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(function(e,te) return te:IsActiveType(typ) end)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	end
	if rc:IsAbleToRemove() then
		Duel.BreakEffect()
		--Banish the card you looked at, face-up, until the End Phase
		aux.RemoveUntil(rc,POS_FACEUP,REASON_EFFECT|REASON_TEMPORARY,PHASE_END,id,e,tp,function(ag) Duel.SendtoHand(ag,nil,REASON_EFFECT) end)
	end
end