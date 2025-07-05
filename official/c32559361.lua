--ＣＮｏ．９ 天蓋妖星カオス・ダイソン・スフィア
--Number C9: Chaos Dyson Sphere
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 10 monsters
	Xyz.AddProcedure(c,nil,10,3)
	--Attach battled monster to this card as an Xyz material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetTarget(s.attachtg)
	e1:SetOperation(s.attachop)
	c:RegisterEffect(e1)
	--Inflict 300 damage to your opponent for each Xyz Material attached to this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.dam300tg)
	e2:SetOperation(s.dam300op)
	c:RegisterEffect(e2)
	--Inflict 800 damage to your opponent for each detached material
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e) return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,1992816) end)
	e3:SetCost(Cost.Detach(1,function(e) return e:GetHandler():GetOverlayCount() end,function(e,og) e:SetLabel(#og) end))
	e3:SetTarget(s.dam800tg)
	e3:SetOperation(s.dam800op)
	c:RegisterEffect(e3)
end
s.xyz_number=9
s.listed_names={1992816}
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and c:IsType(TYPE_XYZ) and not tc:IsType(TYPE_TOKEN) and tc:IsAbleToChangeControler() end
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToBattle() and not tc:IsImmuneToEffect(e) then
		Duel.Overlay(c,tc,true)
	end
end
function s.damtg(amt,ct)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		local ct=e:GetHandler():GetOverlayCount()
		if chk==0 then return ct>0 end
		Duel.SetTargetPlayer(1-tp)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
	end
end
function s.dam300tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetOverlayCount()
	if chk==0 then return ct>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
function s.dam300op(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=e:GetHandler():GetOverlayCount()
	Duel.Damage(p,ct*300,REASON_EFFECT)
end
function s.dam800tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=e:GetLabel()
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*800)
end
function s.dam800op(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=e:GetLabel()
	Duel.Damage(p,ct*800,REASON_EFFECT)
end
