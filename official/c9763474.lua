--盛悴のリザルドーズ
--Haggard Lizardose
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2 monsters with different names
	Link.AddProcedure(c,nil,2,2,function(g) return g:GetClassCount(Card.GetCode)==#g end)
	--Make 1 monster's ATK equal to banished monster's ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.atkcost)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
function s.atkcostfilter(c,tp)
	local atk=c:GetTextAttack()
	if atk<0 then atk=0 end
	return c:IsFaceup() and c:IsAttackBelow(2000) and c:IsAbleToRemoveAsCost() and (not c:IsOriginalRace(RACE_REPTILE) or Duel.IsPlayerCanDraw(tp,1))
		and Duel.IsExistingTarget(aux.FaceupFilter(aux.NOT(Card.IsAttack),atk),tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.atkcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	e:SetLabel(tc:GetTextAttack(),tc:GetOriginalRace())
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk,race=e:GetLabel()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and not chkc:IsAttack(atk) end
	if chk==0 then return true end
	if atk<0 then atk=0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(aux.NOT(Card.IsAttack),atk),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if race&RACE_REPTILE==0 then
		e:SetCategory(CATEGORY_ATKCHANGE)
	else
		e:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	local atk,race=e:GetLabel()
	if atk<0 then atk=0 end
	if tc:IsAttack(atk) then return end
	--Make its ATK equal to the banished monster's original ATK
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(atk)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e1)
	if tc:IsAttack(atk) and race&RACE_REPTILE==RACE_REPTILE then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end