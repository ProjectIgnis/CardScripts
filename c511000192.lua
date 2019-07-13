--Number F0: Future Hope
Duel.LoadCardScript("c65305468.lua")
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	c:EnableReviveLimit()
	s.xyz_filter=function(mc,ignoretoken,xyz,tp) return mc and mc:IsType(TYPE_XYZ,xyz,SUMMON_TYPE_XYZ,tp) and (not mc:IsType(TYPE_TOKEN) or ignoretoken) end
	s.xyz_parameters={s.xyz_filter,nil,2,nil,nil,2}
	s.minxyzct=ct
	s.maxxyzct=maxct
	local chk1=Effect.CreateEffect(c)
	chk1:SetType(EFFECT_TYPE_SINGLE)
	chk1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	chk1:SetCode(946)
	chk1:SetCondition(Xyz.Condition(aux.FilterBoolFunctionEx(Card.IsType,TYPE_XYZ),nil,2,2))
	chk1:SetTarget(Xyz.Target(aux.FilterBoolFunctionEx(Card.IsType,TYPE_XYZ),nil,2,2))
	chk1:SetOperation(s.xyzop)
	c:RegisterEffect(chk1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1073)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Xyz.Condition(aux.FilterBoolFunctionEx(Card.IsType,TYPE_XYZ),nil,2,2))
	e1:SetTarget(Xyz.Target(aux.FilterBoolFunctionEx(Card.IsType,TYPE_XYZ),nil,2,2))
	e1:SetOperation(s.xyzop)
	e1:SetValue(SUMMON_TYPE_XYZ)
	e1:SetLabelObject(chk1)
	c:RegisterEffect(e1)
	--rank
	c:SetStatus(STATUS_NO_LEVEL,true)
	--indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--damage val
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--control
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,0))
	e5:SetCategory(CATEGORY_CONTROL)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_DAMAGE_STEP_END)
	e5:SetTarget(s.atktg)
	e5:SetOperation(s.atkop)
	c:RegisterEffect(e5)
	--prevent destroy
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(59251766,0))
	e7:SetType(EFFECT_TYPE_QUICK_O)
	e7:SetCode(EVENT_FREE_CHAIN)
	e7:SetCountLimit(1)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCost(s.cost)
	e7:SetOperation(s.op2)
	c:RegisterEffect(e7,false,REGISTER_FLAG_DETACH_XMAT)
	--prevent effect damage
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(20450925,0))
	e8:SetType(EFFECT_TYPE_QUICK_O)
	e8:SetCode(EVENT_FREE_CHAIN)
	e8:SetCountLimit(1)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCost(s.cost)
	e8:SetOperation(s.op3)
	c:RegisterEffect(e8,false,REGISTER_FLAG_DETACH_XMAT)
end
s.xyz_number=0
function s.xyzop(e,tp,eg,ep,ev,re,r,rp,c,og,min,max)
	local g=e:GetLabelObject()
	if not g then return end
	local remg=g:Filter(Card.IsHasEffect,nil,511002116)
	remg:ForEach(function(c) c:RegisterFlagEffect(511002115,RESET_EVENT+RESETS_STANDARD,0,0) end)
	g:Remove(Card.IsHasEffect,nil,511002116)
	g:Remove(Card.IsHasEffect,nil,511002115)
	local sg=Group.CreateGroup()
	for tc in aux.Next(g) do
		local sg1=tc:GetOverlayGroup()
		sg:Merge(sg1)
	end
	Duel.Overlay(c,sg)
	c:SetMaterial(g)
	Duel.Overlay(c,g:Filter(function(c) return c:GetEquipTarget() end,nil))
	Duel.Overlay(c,g)
	g:DeleteGroup()
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc end
	Duel.SetTargetCard(bc)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,bc,1,0,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc and bc:IsRelateToBattle() then
		Duel.GetControl(bc,tp,PHASE_BATTLE,1)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		c:RegisterEffect(e2)
	end
end
function s.op3(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.damval)
	e1:SetReset(RESET_PHASE+PHASE_END,1)
	Duel.RegisterEffect(e1,tp)
end
function s.damval(e,re,val,r,rp,rc)
	if (r&REASON_EFFECT)~=0 then return 0
	else return val end
end
