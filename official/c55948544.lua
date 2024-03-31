--ファラオの審判
--Judgment of the Pharaoh
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={81332143,14731897} --"Yu-Jo Friendship", "Unity"
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,81332143)
	local b2=not Duel.HasFlagEffect(tp,id+1)
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,14731897)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local c=e:GetHandler()
	if op==1 and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,81332143)
		and not Duel.HasFlagEffect(tp,id) then
		--If "Yu-Jo Friendship" is in your GY
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		--Your opponent cannot Normal Summon/Set, Flip Summon, Special Summon, or Set a monster until the end of this turn
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SUMMON)
		e1:SetTargetRange(0,1)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_MSET)
		Duel.RegisterEffect(e2,tp)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
		Duel.RegisterEffect(e3,tp)
		local e4=e1:Clone()
		e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		Duel.RegisterEffect(e4,tp)
		local e5=e1:Clone()
		e5:SetCode(EFFECT_CANNOT_TURN_SET)
		Duel.RegisterEffect(e5,tp)
		--Your opponent cannot activate monster effects until the end of this turn
		local e6=e1:Clone()
		e6:SetCode(EFFECT_CANNOT_ACTIVATE)
		e6:SetValue(function(e,re,tp) return re:IsMonsterEffect() end)
		Duel.RegisterEffect(e6,tp)
		--The effects of monsters your opponent controls are negated
		local e7=Effect.CreateEffect(c)
		e7:SetType(EFFECT_TYPE_FIELD)
		e7:SetCode(EFFECT_DISABLE)
		e7:SetTargetRange(0,LOCATION_MZONE)
		e7:SetTarget(function(e,c) return c:IsType(TYPE_EFFECT) or c:IsOriginalType(TYPE_EFFECT) end)
		e7:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e7,tp)
		--Your opponent's monster effects are negated
		local e8=Effect.CreateEffect(c)
		e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e8:SetCode(EVENT_CHAIN_SOLVING)
		e8:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp and re:IsMonsterEffect() end)
		e8:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.NegateEffect(ev) end)
		e8:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e8,tp)
	elseif op==2 and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,14731897)
		and not Duel.HasFlagEffect(tp,id+1) then
		--If "Unity" is in your GY
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		--Your opponent cannot Set Spell/Trap Cards or activate Spell/Trap Cards or effects
		local e9=Effect.CreateEffect(c)
		e9:SetDescription(aux.Stringid(id,4))
		e9:SetType(EFFECT_TYPE_FIELD)
		e9:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e9:SetCode(EFFECT_CANNOT_SSET)
		e9:SetTargetRange(0,1)
		e9:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e9,tp)
		local e10=e9:Clone()
		e10:SetCode(EFFECT_CANNOT_ACTIVATE)
		e10:SetValue(function(e,re,tp) return re:IsSpellTrapEffect() end)
		Duel.RegisterEffect(e10,tp)
		--The effects of Spells/Traps your opponent controls are negated
		local e11=Effect.CreateEffect(c)
		e11:SetType(EFFECT_TYPE_FIELD)
		e11:SetCode(EFFECT_DISABLE)
		e11:SetTargetRange(0,LOCATION_SZONE)
		e11:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e11,tp)
		local e12=e11:Clone()
		e12:SetCode(EFFECT_DISABLE_TRAPMONSTER)
		e12:SetTargetRange(0,LOCATION_MZONE)
		Duel.RegisterEffect(e12,tp)
		--Your opponent's Spell/Trap effects are negated
		local e13=Effect.CreateEffect(c)
		e13:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e13:SetCode(EVENT_CHAIN_SOLVING)
		e13:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp and re:IsSpellTrapEffect() end)
		e13:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.NegateEffect(ev) end)
		e13:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e13,tp)
	end
end