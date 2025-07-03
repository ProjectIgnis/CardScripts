--クリフォトン (Anime)
--Kuriphoton (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Make one instance of damage 0 by paying half your LP and sending this card from  your hand to the GY (Battle damage)
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetType(EFFECT_TYPE_QUICK_O)
	e1a:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1a:SetRange(LOCATION_HAND)
	e1a:SetCondition(function(e) return Duel.GetBattleDamage(e:GetHandlerPlayer())>0 end)
	e1a:SetCost(Cost.AND(Cost.PayLP(1/2),Cost.SelfToGrave))
	e1a:SetOperation(s.nobattledamop)
	c:RegisterEffect(e1a)
	--Make one instance of damage 0 by paying half your LP and sending this card from  your hand to the GY (Effect damage)
	local e1b=Effect.CreateEffect(c)
	e1b:SetDescription(aux.Stringid(id,1))
	e1b:SetType(EFFECT_TYPE_QUICK_O)
	e1b:SetCode(EVENT_CHAINING)
	e1b:SetRange(LOCATION_HAND)
	e1b:SetCondition(aux.damcon1)
	e1b:SetCost(Cost.AND(Cost.PayLP(1/2),Cost.SelfToGrave))
	e1b:SetOperation(s.noeffectdamop)
	c:RegisterEffect(e1b)
	--Send 1 "Photon" card from your hand to the GY to add this card from your GY to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_PHOTON}
function s.nobattledamop(e,tp,eg,ep,ev,re,r,rp)
	--Prevent battle damage
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_DAMAGE_CAL)
	Duel.RegisterEffect(e1,tp)
end
function s.noeffectdamop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		--Prevent effect damage
		local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetLabel(cid)
		e1:SetValue(s.effdamval)
		e1:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.effdamval(e,re,val,r,rp,rc)
	local cc=Duel.GetCurrentChain()
	if cc==0 or (r&REASON_EFFECT)==0 then return val end
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return val end
	return 0
end
function s.thcostfilter(c)
	return c:IsSetCard(SET_PHOTON) and c:IsAbleToGraveAsCost()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thcostfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.thcostfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
