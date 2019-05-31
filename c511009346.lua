--Protector Adoration
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1e0)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetLabelObject(e1)
	e2:SetCondition(s.tgcon)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	--Disable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.indestg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--indes
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_ATTACK_ALL)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(s.indestg)
	e4:SetValue(s.atkfilter)
	c:RegisterEffect(e4)
	
	--destroy at end of BP
	--damage
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79580323,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.descon)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
		
	--Destroy
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(s.descon)
	e5:SetOperation(s.desop)
	c:RegisterEffect(e5)
	
	if not s.global_check then
		s.global_check=true
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_BATTLED)
		ge2:SetOperation(s.battleop)
		Duel.RegisterEffect(ge2,0)
	end
end
s.listed_names={511009337}
function s.filter(c)
	return c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return re==e:GetLabelObject()
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS):GetFirst()
	if c:IsRelateToEffect(re) and tc:IsFaceup() and tc:IsRelateToEffect(re) then
		c:SetCardTarget(tc)
		
		if Duel.IsPlayerCanSpecialSummonMonster(tp,511009337,0,TYPES_TOKEN,0,0,1,RACE_WARRIOR,ATTRIBUTE_LIGHT) 
		and Duel.SelectYesNo(tp,aux.Stringid(57103969,0)) 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		then
		for i=1,2 do
			local token=Duel.CreateToken(tp,511009337)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			token:RegisterEffect(e2,true)
		end
		Duel.SpecialSummonComplete()
		
	end
	end
end
function s.indestg(e,c)
	return e:GetHandler():IsHasCardTarget(c)
end
function s.atkfilter(e,c)
	return c:IsCode(511009337)
end
--destroy at end of Battle phase
function s.tokfilter(c,rc)
	return c:IsCode(511009337) and not c:IsRelateToCard(rc)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.tokfilter,tp,LOCATION_MZONE,0,1,nil,e:GetHandler()) and tp==Duel.GetTurnPlayer()
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	local g=Group.FromCards(tc,c)
	Duel.Destroy(g,REASON_EFFECT)
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end


function s.battleop(e,tp,eg,ep,ev,re,r,rp)
	local dc=Duel.GetAttackTarget()
	if not dc then return end
	local bc=dc:GetBattleTarget()
	if not bc:IsCode(511009337) or not dc:IsCode(511009337) then return end
	if dc:IsControler(1-tp) then dc,bc=bc,dc end
	if dc:IsControler(tp) then
		-- dc:RegisterFlagEffect(511001825+tp,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
		dc:CreateRelation(c,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE) 
	end
	if bc:IsControler(1-tp) then
		-- bc:RegisterFlagEffect(511001825+1-tp,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
		bc:CreateRelation(c,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE) 
	end
end