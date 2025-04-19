--ファンタジスタ・ディエチ
--Playmaker
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	--Flip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.postg)
	e1:SetOperation(s.posop)
	c:RegisterEffect(e1)
	--Chain attack
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.cacon)
	e2:SetCost(Cost.Detach(1))
	e2:SetTarget(s.catg)
	e2:SetOperation(s.caop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
end
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.ChangePosition(g,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,true)
end
function s.cacon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return  Duel.GetAttacker()==c and Duel.GetAttackTarget()~=nil and c:CanChainAttack(0,true)
end
function s.catg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil):GetMaxGroup(Card.GetAttack)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return g:IsExists(Card.IsCanBeEffectTarget,1,nil,e) end
	local tg=g:Filter(Card.IsCanBeEffectTarget,nil,e)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=g:Select(tp,1,1,nil)
	Duel.SetTargetCard(tc)
end
function s.caop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.ChainAttack(tc)
	end
end