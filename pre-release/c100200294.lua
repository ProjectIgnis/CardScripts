--パワーコネクション
--Power Connection
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Target any number of face-up monsters you control (if you target 2 or more monsters, they must have the same Type); they gain 500 ATK for each monster targeted, until the end of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--If you activated "Armament Reincarnation" this turn: You can add this card from your GY to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp) return Duel.HasFlagEffect(tp,id) end)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Keep track of a player activating "Armament Reincarnation"
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(53770666) then
				Duel.RegisterFlagEffect(ep,id,RESET_PHASE|PHASE_END,0,1)
			end
		end)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_names={53770666} --"Armament Reincarnation"
function s.rescon(sg,e,tp,mg)
	return #sg==1 or sg:GetClassCount(Card.GetRace)==1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.GetTargetGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	local tg=aux.SelectUnselectGroup(g,e,tp,1,#g,s.rescon,1,tp,HINTMSG_ATKDEF)
	Duel.SetTargetCard(tg)
	local target_count=#tg
	e:SetLabel(target_count)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tg,target_count,tp,500*target_count)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e):Match(Card.IsFaceup,nil)
	if #tg==0 then return end
	local c=e:GetHandler()
	local atk=500*e:GetLabel()
	for tc in tg:Iter() do
		--They gain 500 ATK for each monster targeted, until the end of this turn
		tc:UpdateAttack(atk,RESETS_STANDARD_PHASE_END,c)
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end