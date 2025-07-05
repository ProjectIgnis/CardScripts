--リリカル・ルスキニア－プロム・スラッシ
--Lyrilusc - Promenade Thrush
--scripted by Rundas
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2+ Level 1 monsters
	Xyz.AddProcedure(c,nil,1,2,nil,nil,Xyz.InfiniteMats)
	--Gains 500 ATK for each material attached to it
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(function(e) return e:GetHandler():GetOverlayCount()*500 end)
	c:RegisterEffect(e1)
	--Shuffle 1 Spell/Trap your opponent controls into the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(Cost.Detach(1))
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	--Make 1 monster you control gain 300 ATK for each material detached
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetCost(Cost.Detach(1,function(e) return e:GetHandler():GetOverlayCount() end,function(e,og) e:SetLabel(#og) end))
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.filter(chkc) and chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.AND(Card.IsSpellTrap,Card.IsAbleToDeck),tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,aux.AND(Card.IsSpellTrap,Card.IsAbleToDeck),tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=Duel.GetBattleMonster(tp)
	return bc and bc:IsFaceup()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetBattleMonster(tp)
	if bc and bc:IsFaceup() and bc:IsRelateToBattle() then
		bc:UpdateAttack(e:GetLabel()*300,RESET_PHASE|PHASE_END,e:GetHandler())
	end
end
