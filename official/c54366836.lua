--Ｎｏ．５４ 反骨の闘士ライオンハート
--Number 54: Lion Heart
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 1 monsters
	Xyz.AddProcedure(c,nil,1,3)
	--This Attack Position card cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return e:GetHandler():IsAttackPos() end)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Inflict damage to your opponent equal to the battle damage you took
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==tp and e:GetHandler():IsRelateToBattle() end)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
	--Your opponent takes any battle damage you would have taken from that battle
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e,tp) local bc=e:GetHandler():GetBattleTarget() return bc and bc:IsControler(1-tp) end)
	e3:SetCost(Cost.AND(Cost.Detach(1),Cost.SoftOncePerBattle))
	e3:SetOperation(s.reversedamop)
	c:RegisterEffect(e3)
end
s.xyz_number=54
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(ev)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ev)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.reversedamop(e,tp,eg,ep,ev,re,r,rp)
	--Your opponent takes any battle damage you would have taken from that battle
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_DAMAGE_CAL)
	Duel.RegisterEffect(e1,tp)
end