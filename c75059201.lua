--F.A.ターボチャージャー
--F.A. Turbo Charger
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--untargetable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.atglimit)
	e2:SetValue(s.atlimit)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.tglimit)
	e3:SetValue(s.tgval)
	c:RegisterEffect(e3)
	--lv up
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_LVCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.lvcon)
	e4:SetOperation(s.lvop)
	c:RegisterEffect(e4)
	--actlimit
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,1)
	e5:SetValue(s.aclimit)
	e5:SetCondition(s.actcon)
	c:RegisterEffect(e5)
end
s.listed_series={0x107}
function s.atkval(e,c)
	return c:GetLevel()*300
end
function s.atglimit(e,c)
	local lv=e:GetHandler():GetLevel()
	if c:GetRank()>0 then
		return c:GetOriginalRank()<lv
	elseif c:HasLevel() then
		return c:GetOriginalLevel()<lv
	else return false end
end
function s.atlimit(e,c)
	return c~=e:GetHandler()
end
function s.tglimit(e,c)
	return c~=e:GetHandler()
end
function s.tgval(e,re,rp)
	if not aux.tgoval(e,re,rp) then return false end
	local c=re:GetHandler()
	local lv=e:GetHandler():GetLevel()
	if c:GetRank()>0 then
		return c:GetOriginalRank()<lv
	elseif c:HasLevel() then
		return c:GetOriginalLevel()<lv
	else return false end
end
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:GetHandler():IsSetCard(0x107) and e:GetHandler():GetFlagEffect(1)>0
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
function s.actcon(e)
	if not e:GetHandler():IsLevelAbove(7) then return false end
	local a=Duel.GetAttacker()
	if not a then return false end
	local d=a:GetBattleTarget()
	if a:IsControler(1-e:GetHandler():GetControler()) then a,d=d,a end
	return a and a:IsSetCard(0x107)
end
