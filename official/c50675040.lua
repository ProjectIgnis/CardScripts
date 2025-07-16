--獣王無塵
--Beast King Unleashed
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Return your monster and any other cards in its column to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.thcon)
	e1:SetCost(Cost.HardOncePerChain(id))
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local bc1,bc2=Duel.GetBattleMonster(tp)
	return bc1 and bc2 and bc1:IsColumn(bc2:GetSequence(),1-tp,LOCATION_MZONE)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=Duel.GetBattleMonster(tp)
	local colg=bc:GetColumnGroup():Match(Card.IsAbleToHand,nil)
	if chk==0 then return bc:IsAbleToHand() and #colg>0 end
	e:SetLabelObject(bc)
	bc:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,colg+bc,#colg,tp,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToEffect(e) and bc:IsControler(tp) then
		local colg=bc:GetColumnGroup()+bc
		if #colg>0 then
			Duel.SendtoHand(colg,nil,REASON_EFFECT)
		end
	end
end