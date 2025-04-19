--ランク・ドミネーション
--Rank Domination
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Monsters without Ranks cannot attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(function(e,c) return c:GetRank()<=0 end)
	c:RegisterEffect(e2)
	--Monsters must attack in order of Rank, starting from lowest
	local e3=e2:Clone()
	e3:SetTarget(s.rkotarget)
	c:RegisterEffect(e3)
	--Battling monsters with lower Rank lose ATK equal to difference in Rank x 1000
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
function s.rkofilter(c,rk)
	local atkct=c:GetEffectCount(EFFECT_EXTRA_ATTACK)+1
	return c:IsFaceup() and c:GetRank()>0 and c:GetRank()<rk and c:CanAttack() and c:GetAttackedCount()<atkct
end
function s.rkotarget(e,c)
	local rk=c:GetRank()
	local p=c:GetControler()
	return c:IsFaceup() and rk>0 and Duel.IsExistingMatchingCard(s.rkofilter,p,LOCATION_MZONE,0,1,nil,rk)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if chk==0 then return a and a:GetRank()>0 and d and d:GetRank()>0 and a:GetRank()~=d:GetRank() end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not a or not d or a:GetRank()==d:GetRank() then return false end
	local rk=math.abs(a:GetRank()-d:GetRank())
	if a:GetRank()>d:GetRank() then
		local e1=Effect.CreateEffect(e:GetHandler())
        	e1:SetType(EFFECT_TYPE_SINGLE)
        	e1:SetCode(EFFECT_UPDATE_ATTACK)
        	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        	e1:SetRange(LOCATION_MZONE)
        	e1:SetValue(-rk*1000)
        	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
        	d:RegisterEffect(e1)
   	else
        	local e1=Effect.CreateEffect(e:GetHandler())
        	e1:SetType(EFFECT_TYPE_SINGLE)
        	e1:SetCode(EFFECT_UPDATE_ATTACK)
        	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
        	e1:SetRange(LOCATION_MZONE)
        	e1:SetValue(-rk*1000)
        	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
        	a:RegisterEffect(e1)
    	end
end