--No.16 色の支配者ショック・ルーラー
Duel.LoadCardScript("c54719828.lua")
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	--act limit
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54719828,0))
	e1:SetProperty(0,EFFECT_FLAG2_XMDETACH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--battle indestructable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(s.indes)
	c:RegisterEffect(e2)
end
s.xyz_number=16
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(54719828,1))
	local op=Duel.SelectOption(tp,70,71,72)
	local c=e:GetHandler()
	--disable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(0,0xff)
	e1:SetTarget(s.distarget)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	e1:SetLabel(op)
	Duel.RegisterEffect(e1,tp)
	--disable effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetOperation(s.disoperation)
	e2:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	e2:SetLabel(op)
	Duel.RegisterEffect(e2,tp)
	--disable trap monster
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e3:SetTargetRange(0,0xff)
	e3:SetTarget(s.distarget)
	e3:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	e3:SetLabel(op)
	Duel.RegisterEffect(e3,tp)
end
function s.distarget(e,c)
	local type=0
	if e:GetLabel()==0 then
		type=TYPE_MONSTER
	elseif e:GetLabel()==1 then
		type=TYPE_SPELL
	else
		type=TYPE_TRAP
	end
	return c:IsType(type)
end
function s.disoperation(e,tp,eg,ep,ev,re,r,rp)
	local type=0
	if e:GetLabel()==0 then
		type=TYPE_MONSTER
	elseif e:GetLabel()==1 then
		type=TYPE_SPELL
	else
		type=TYPE_TRAP
	end
	if re:IsActiveType(type) and re:GetHandler():IsControler(1-tp) then
		Duel.NegateEffect(ev)
	end
end
function s.indes(e,c)
	return not c:IsSetCard(0x48)
end
