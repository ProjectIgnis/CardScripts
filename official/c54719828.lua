--Ｎｏ．１６ 色の支配者ショック・ルーラー
--Number 16: Shock Master
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,3)
	--Declare 1 card type (Monster, Spell, or Trap); that type of card (if Spell or Trap) cannot be activated, or (if Monster) cannot activate its effects, until the end of your opponent's next turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(Cost.DetachFromSelf(1))
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.xyz_number=16
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=not Duel.HasFlagEffect(tp,id+1)
	local b2=not Duel.HasFlagEffect(tp,id+2)
	local b3=not Duel.HasFlagEffect(tp,id+3)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,DECLTYPE_MONSTER},
		{b2,DECLTYPE_SPELL},
		{b3,DECLTYPE_TRAP})
	e:SetLabel(op)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if Duel.HasFlagEffect(tp,id+op) then return end
	Duel.RegisterFlagEffect(tp,id+op,RESET_PHASE|PHASE_END,0,1)
	--That type of card (if Spell or Trap) cannot be activated, or (if Monster) cannot activate its effects, until the end of your opponent's next turn
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,op))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,1)
	if op==1 then
		e1:SetValue(function(e,re,tp) return re:IsMonsterEffect() end)
	elseif op==2 then
		e1:SetValue(function(e,re,tp) return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsSpellEffect() end)
	elseif op==3 then
		e1:SetValue(function(e,re,tp) return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsTrapEffect() end)
	end
	e1:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,1)
	Duel.RegisterEffect(e1,tp)
end