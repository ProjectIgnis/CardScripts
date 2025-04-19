--連鎖破壊 (Manga)
--Chain Destruction (Manga)
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 of those Summoned monsters, and if you do, destroy all copies of it in the controller's Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
function s.filter(c,e)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsAttackBelow(2000) and c:IsCanBeEffectTarget(e)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) end
	if chk==0 then return eg:IsExists(s.filter,1,nil,e) end
	if #eg==1 then
		Duel.SetTargetCard(eg)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,eg:GetFirst():GetControler(),LOCATION_DECK)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local g=eg:FilterSelect(tp,s.filter,1,1,nil,e)
		Duel.SetTargetCard(g)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,g:GetFirst():GetControler(),LOCATION_DECK)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		local tpe=tc:GetType()
		if (tpe&TYPE_TOKEN)~=0 then return end
		local dg=Duel.GetMatchingGroup(Card.IsOriginalCodeRule,tc:GetControler(),LOCATION_DECK,0,nil,tc:GetOriginalCodeRule())
		Duel.Destroy(dg,REASON_EFFECT)
	end
end