--Ｎｏ．６ 先史遺産－アトランタル (Anime)
--Number 6: Chronomaly Atlandis (Anime)
Duel.LoadCardScript("c9161357.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 6 monsters
	Xyz.AddProcedure(c,nil,6,2)
	--Cannot be destroyed by battle, except with "Number" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,SET_NUMBER)))
	c:RegisterEffect(e1)
	--When this card is Xyz Summoned: You can target 1 "Number" monster in your GY; equip it to this card.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9161357,0))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	aux.AddEREquipLimit(c,s.eqcon,s.eqval,s.equipop,e2)
	--Once per turn: You can detach 1 Xyz Material from this card; halve your opponent's LP
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9161357,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(Cost.DetachFromSelf(1))
	e3:SetOperation(function(e) local tp=e:GetHandlerPlayer() Duel.SetLP(1-tp,Duel.GetLP(1-tp)/2))
	c:RegisterEffect(e3)
	--If this card has no materials: Halve both players' LP during your Standby Phase
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(52090844,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) and e:GetHandler():GetOverlayCount()==0 end)
	e4:SetOperation(s.hlpop)
	c:RegisterEffect(e4)
	--This card cannot be destroyed by battle while your LP are 1000 or less by the above effect, also you take no battle damage
	local e5a=Effect.CreateEffect(c)
	e5a:SetType(EFFECT_TYPE_SINGLE)
	e5a:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e5a:SetCondition(function(e) return Duel.HasFlagEffect(e:GetHandlerPlayer(),id) end)
	e5a:SetValue(1)
	c:RegisterEffect(e5a)
	local e5b=Effect.CreateEffect(c)
	e5b:SetType(EFFECT_TYPE_FIELD)
	e5b:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5b:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e5b:SetCondition(function(e) return Duel.HasFlagEffect(e:GetHandlerPlayer(),id) end)
	e5b:SetRange(LOCATION_MZONE)
	e5b:SetTargetRange(1,0)
	c:RegisterEffect(e5b)
	--Check for LP to register battle indestructibility/damage avoidance
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(s.lpchk)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={SET_NUMBER}
s.xyz_number=6
function s.lpchk(e,tp,eg,ep,ev,re,r,rp)
	local prevlp1=s[tp]
	local prevlp2=s[1-tp]
	if prevlp1<=1000 and Duel.GetLP(tp)>1000 then
		Duel.ResetFlagEffect(tp,id)
	end
	if prevlp2<=1000 and Duel.GetLP(1-tp)>1000 then
		Duel.ResetFlagEffect(1-tp,id)
	end
	s[tp]=Duel.GetLP(tp)
	s[1-tp]=Duel.GetLP(1-tp)
end
function s.eqval(ec,c,tp)
	return ec:IsControler(tp) and ec:IsSetCard(SET_NUMBER)
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsXyzSummoned()
end
function s.eqfilter(c)
	return c:IsSetCard(SET_NUMBER) and c:IsMonster()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function s.equipop(c,e,tp,tc)
	if not c:EquipByEffectAndLimitRegister(e,tp,tc) then return end
	local atk=tc:GetBaseAttack()
	if atk>0 then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
	end
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) then
		s.equipop(c,e,tp,tc)
	end
end
function s.halvelpop(e,tp,eg,ep,ev,re,r,rp)
	local lp=Duel.GetLP(tp)
	Duel.SetLP(tp,lp/2)
	Duel.SetLP(1-tp,Duel.GetLP(1-tp)/2)
	if lp>1000 and Duel.GetLP(tp)<=1000 then
		Duel.RegisterFlagEffect(tp,id,0,0,0)
	end
end
