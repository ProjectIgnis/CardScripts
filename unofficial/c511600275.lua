--コードブレイク・バインド
--Codebreak Bind
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.actcon)
	c:RegisterEffect(e1)
	--Self destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.descon)
	c:RegisterEffect(e2)
	--cannot attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(s.atg)
	c:RegisterEffect(e3)
	--damage
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(s.damtg)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
end
s.listed_series={0x13c}
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x13c)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13c) and c:IsLinkMonster()
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.descon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_END
		and not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.atg(e,c)
	local lg=Group.CreateGroup()
	for lc in aux.Next(Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)) do
		lg=lg+lc:GetLinkedGroup()
	end
	return not lg:IsContains(c)
end
function s.sfilter(c,tp,lg)
	return c:GetSummonPlayer()~=tp and lg:IsContains(c)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=Group.CreateGroup()
	for lc in aux.Next(Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)) do
		lg=lg+lc:GetLinkedGroup()
	end
	if chk==0 then return eg:IsExists(s.sfilter,1,nil,tp,lg) end
	Duel.SetTargetCard(eg:Filter(s.sfilter,nil,tp,lg))
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetTargetCards(e):Filter(aux.NOT(Card.IsControler),nil,tp)
	if #g>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_BATTLE_DESTROYED)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCondition(s.con)
		e1:SetOperation(s.op)
		e:GetHandler():RegisterEffect(e1)
		for gc in aux.Next(g) do
			gc:CreateEffectRelation(e1)
		end
	end
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local des=eg:GetFirst()
	local rc=des:GetReasonCard()
	return des:IsLocation(LOCATION_GRAVE) and rc:IsRelateToBattle() and rc:IsRelateToEffect(e)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT) then
		Duel.BreakEffect()
		Duel.Damage(1-tp,eg:GetFirst():GetBaseAttack(),REASON_EFFECT)
	end
end
