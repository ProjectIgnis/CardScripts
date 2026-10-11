--N・グラン・モール
--Neo-Spacian Grand Mole
local s,id=GetID()
function s.initial_effect(c)
	--At the start of the Damage Step, if this card battles an opponent's monster: You can return both the opponent's monster and this card to the hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local monster1,monster2=Duel.GetBattleMonster(tp)
	return monster1 and monster2
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local monster1,monster2=Duel.GetBattleMonster(tp)
	if chk==0 then return monster1:IsAbleToHand() and monster2:IsAbleToHand() end
	local g=Group.FromCards(monster1,monster2)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	local monster1,monster2=Duel.GetBattleMonster(tp)
	if monster1 and monster2 and monster1:IsRelateToBattle() and monster2:IsRelateToBattle() then
		local g=Group.FromCards(monster1,monster2)
		if #g==2 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end