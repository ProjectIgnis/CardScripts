--天子の指輪
--Angelica's Angelic Ring
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Equip only to a monster you control that is equipped with an Equip Card
	aux.AddEquipProcedure(c,nil,s.eqfilter)
	--Can only control 1 "Angel Ring"
	c:SetUniqueOnField(1,0,id)
	--Negate an opponent's activated Spell effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp and re:IsSpellEffect() and Duel.IsChainDisablable(ev) end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.NegateEffect(ev) end)
	c:RegisterEffect(e1)
	--Gain 500 LP, then destroy this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_RECOVER+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e) return e:GetHandler():GetEquipTarget() end)
	e2:SetTarget(s.lptg)
	e2:SetOperation(s.lpop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
function s.eqfilter(c,e,tp)
	return c:IsControler(tp) and c:GetEquipCount()>0
end
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,tp,0)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Recover(p,d,REASON_EFFECT)==0 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	local tc=c:GetPreviousEquipTarget()
	if tc:IsFacedown() then return end
	--Opponent cannot target the monster this card was equipped to with card effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3061)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,re,rp) return rp==1-e:GetOwnerPlayer() end)
	e1:SetOwnerPlayer(tp)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	tc:RegisterEffect(e1)
end