--Lyrical Luscinia - Independent Nightingale
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,48608796,aux.FilterBoolFunctionEx(Card.IsSetCard,0xf7))
	--level
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.valcheck)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetCondition(s.lvcon)
	e2:SetValue(s.lvval)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--Atk update
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SET_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	--damage
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(17415895,0))
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
s.listed_names={48608796}
s.material_setcode=0xf7
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local lvl=0
	local tc=g:GetFirst()
	if not tc then return end
	if not tc:IsCode(48608796) then tc=g:GetNext() end
	if tc:IsCode(48608796) then
		lvl=tc:GetOverlayCount()
	end
	e:SetLabel(lvl)
end
function s.lvcon(e)
	return (e:GetHandler():GetSummonType()&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
function s.lvval(e,c)
	return e:GetLabelObject():GetLabel()
end
function s.atkval(e,c)
	local c=e:GetHandler()
	local atk=c:GetBaseAttack()+(c:GetLevel()*500)
	if atk<0 then atk=0 end
	return atk
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetLevel()>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local dam=e:GetHandler():GetLevel()*500
	Duel.Damage(p,dam,REASON_EFFECT)
end
