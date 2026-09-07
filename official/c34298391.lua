--心を見通す眼
--Mind Scan
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e0)
	--While you have a "Toon" card in your field or GY, your opponent must keep their hand revealed, also you can look at their Set cards at any time
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_PUBLIC)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(function(e) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_TOON),e:GetHandlerPlayer(),LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil) end)
	e1:SetTargetRange(0,LOCATION_HAND|LOCATION_ONFIELD)
	c:RegisterEffect(e1)
	--If you have a Toon monster and a "Toon" Spell in your field and/or GY: You can declare 1 card name that is not among the cards/effects activated in this Chain; negate the activated effects of cards with that original name until the end of this turn, while this card is face-up on the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.declcon)
	e2:SetTarget(s.decltg)
	e2:SetOperation(s.declop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_series={SET_TOON}
function s.declconfilter(c)
	return ((c:IsType(TYPE_TOON) and c:IsMonster()) or (c:IsSetCard(SET_TOON) and c:IsSpell())) and c:IsFaceup()
end
function s.declcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroup(s.declconfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,nil):GetClassCount(Card.GetMainCardType)==2
end
function s.decltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local current_chain=Duel.GetCurrentChain()
	s.announce_filter={TYPE_NORMAL,OPCODE_ISTYPE,OPCODE_NOT}
	if current_chain>1 then
		for i=1,current_chain-1 do
			local trig_code1,trig_code2=Duel.GetChainInfo(i,CHAININFO_TRIGGERING_CODE,CHAININFO_TRIGGERING_CODE2)
			table.insert(s.announce_filter,trig_code1)
			table.insert(s.announce_filter,OPCODE_ISCODE)
			table.insert(s.announce_filter,OPCODE_NOT)
			table.insert(s.announce_filter,OPCODE_AND)
			if trig_code2>0 then
				table.insert(s.announce_filter,trig_code2)
				table.insert(s.announce_filter,OPCODE_ISCODE)
				table.insert(s.announce_filter,OPCODE_NOT)
				table.insert(s.announce_filter,OPCODE_AND)
			end
		end
	end
	local declared_code=Duel.AnnounceCard(tp,s.announce_filter)
	Duel.SetTargetParam(declared_code)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
end
function s.declop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local declared_code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		c:SetHint(CHINT_CARD,declared_code)
		--Clear the hint at the end of the turn
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetCode(EVENT_TURN_END)
		e0:SetRange(LOCATION_SZONE)
		e0:SetCountLimit(1)
		e0:SetOperation(function(e) c:SetHint(CHINT_CARD,0) e:Reset() end)
		e0:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e0)
		--Negate the activated effects of cards with that original name until the end of this turn, while this card is face-up on the field
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
				local code1,code2=re:GetHandler():GetOriginalCodeRule()
				return code1==declared_code or code2==declared_code
			end)
		e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
				Duel.NegateEffect(ev)
			end)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	end
end