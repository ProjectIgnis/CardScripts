--Dazzling Radiance
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMinGroup(Card.GetAttack) or Group.CreateGroup()
	local sg=tg:Filter(aux.TRUE,Group.FromCards(Duel.GetAttacker(),Duel.GetAttackTarget()))
	if chk==0 then return #sg>0 end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,sg,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMinGroup(Card.GetAttack) or Group.CreateGroup()
	local sg=tg:Filter(aux.TRUE,Group.FromCards(Duel.GetAttacker(),Duel.GetAttackTarget()))
	if #sg>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		sg=sg:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
	end
	local sc=sg:GetFirst()
	if sc and Duel.GetControl(sc,tp) then
		Duel.ChangeAttackTarget(sc)
	end
end
