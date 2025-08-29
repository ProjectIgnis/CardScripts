--糾罪巧－Ａｉｚａβ.ＬＥＯＮ
--Enneacraft - Aizaβ.LEON
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SINQUISITION,LOCATION_PZONE)
	Pendulum.AddProcedure(c)
	--Each time a monster(s) is flipped face-up, place 1 Sinquisition Counter on this card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FLIP)
	e1:SetRange(LOCATION_PZONE)
	e1:SetOperation(s.counterop)
	c:RegisterEffect(e1)
	--Destroy 1 monster your opponent controls with less ATK than this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PHASE|PHASE_BATTLE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--Special Summon 1 monster from your hand in face-down Defense Position
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCost(Cost.AND(Cost.SelfReveal,s.spcost))
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(c) return c:IsPosition(POS_FACEDOWN_DEFENSE) end)
	--Return up to 3 cards on the field to the hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.rthcon)
	e4:SetCost(Cost.SelfChangePosition(POS_FACEUP_DEFENSE))
	e4:SetTarget(s.rthtg)
	e4:SetOperation(s.rthop)
	c:RegisterEffect(e4)
	--Each time a card(s) is added to your opponent's hand by their card effect, inflict 900 damage to your opponent for each
	local e5a=Effect.CreateEffect(c)
	e5a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5a:SetCode(EVENT_FLIP)
	e5a:SetOperation(function(e)
				local c=e:GetHandler()
				c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
				local chain_link=Duel.GetCurrentChain()
				if chain_link==0 then return end
				local fid=c:GetFieldID()
				local tp=e:GetHandlerPlayer()
				--Workaround to have e5b apply immediately if it's flipped face-up due to its own effect
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_TO_HAND)
				e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.GetCurrentChain()>chain_link and e:GetHandler():HasFlagEffect(id) and rp==1-tp and r&REASON_EFFECT>0 and eg:IsExists(Card.IsControler,1,nil,1-tp) end)
				e1:SetOperation(s.damop)
				e1:SetReset(RESET_CHAIN)
				Duel.RegisterEffect(e1,tp)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e2:SetProperty(EFFECT_FLAG_DELAY)
				e2:SetCode(EVENT_CHAIN_SOLVED)
				e2:SetCondition(function() return c:HasFlagEffect(id) and c:IsFaceup() and not c:IsDisabled() and c:IsFieldID(fid) end)
				e2:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) e1:Reset() e2:Reset() s.chainsolvedop(e,tp,eg,ep,ev,re,r,rp) end)
				e2:SetReset(RESET_CHAIN)
				Duel.RegisterEffect(e2,tp)
			end)
	c:RegisterEffect(e5a)
	local e5b=Effect.CreateEffect(c)
	e5b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5b:SetCode(EVENT_TO_HAND)
	e5b:SetRange(LOCATION_MZONE)
	e5b:SetCondition(s.damcon)
	e5b:SetOperation(s.damop)
	c:RegisterEffect(e5b)
	local e5c=Effect.CreateEffect(c)
	e5c:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5c:SetProperty(EFFECT_FLAG_DELAY)
	e5c:SetCode(EVENT_CHAIN_SOLVED)
	e5c:SetRange(LOCATION_MZONE)
	e5c:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e5c:SetOperation(s.chainsolvedop)
	c:RegisterEffect(e5c)
end
s.counter_place_list={COUNTER_SINQUISITION}
s.listed_series={SET_ENNEACRAFT}
function s.counterop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.IsChainSolving() then
		c:AddCounter(COUNTER_SINQUISITION,1)
	else
		--Place 1 Sinquisition Counter on this card at the end of the Chain Link
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVED)
		e1:SetRange(LOCATION_PZONE)
		e1:SetOperation(function() c:AddCounter(COUNTER_SINQUISITION,1) end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CHAIN)
		c:RegisterEffect(e1)
		--Reset "e1" at the end of the Chain Link
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVED)
		e2:SetOperation(function() e1:Reset() end)
		e2:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local pc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,e:GetHandler())
	return pc and pc:IsSetCard(SET_ENNEACRAFT)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk=e:GetHandler():GetAttack()-1
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsAttackBelow(atk) end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsAttackBelow,atk),tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsAttackBelow,atk),tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	--You cannot Special Summon the turn you activate this effect, except in face-down Defense Position
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
	e1:SetTargetRange(1,0)
	e1:SetValue(POS_FACEDOWN_DEFENSE)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,tp,LOCATION_HAND,0,1,nil,e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,Card.IsCanBeSpecialSummoned,tp,LOCATION_HAND,0,1,1,nil,e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
	end
end
function s.rthcon(e,tp,eg,ep,ev,re,r,rp)
	local ch=Duel.GetCurrentChain()-1
	return e:GetHandler():IsFacedown() and ch>0 and ep==1-tp and Duel.GetChainInfo(ch,CHAININFO_TRIGGERING_CONTROLER)==tp
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,3,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():HasFlagEffect(id) and rp==1-tp and r&REASON_EFFECT>0 and eg:IsExists(Card.IsControler,1,nil,1-tp)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(Card.IsControler,nil,1-tp)
	if Duel.IsChainSolving() then
		--If a chain link is resolving, register a flag to deal the damage after it
		local c=e:GetHandler()
		for i=1,ct do
			c:RegisterFlagEffect(id+1,RESET_CHAIN,0,1)
		end
	else
		--If a chain is not resolving, deal the damage right away
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.Damage(1-tp,ct*900,REASON_EFFECT)
	end
end
function s.chainsolvedop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetFlagEffect(id+1)
	if ct>0 then
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.Damage(1-tp,ct*900,REASON_EFFECT)
		e:GetHandler():ResetFlagEffect(id+1)
	end
end