--連鎖破壊
--Chain Destruction
local s,id=GetID()
function s.initial_effect(c)
	--Activate
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
function s.tgfilter(c,e,tp)
	if not (c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsAttackBelow(2000) and c:IsCanBeEffectTarget(e)) then return false end
	if c:IsControler(tp) then
		return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,c:GetCode())
	else
		return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND|LOCATION_DECK,0)>0 and s.mdnamecheck(c)
	end
end
function s.mdnamecheck(c)
	local codes={c:GetCode()}
	for _,code in ipairs(codes) do
		local typ=Duel.GetCardTypeFromCode(code)
		if typ&(TYPE_TOKEN|TYPE_EXTRA)==0 then
			return true
		end
	end
	return false
end
function s.publicfilter(c,convulsion,top_card,...)
	return c:IsCode(...) and (c:IsPublic() or (convulsion and c==top_card))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=eg:Filter(s.tgfilter,nil,e,tp)
	if chkc then return tg:IsContains(chkc) end
	if chk==0 then return #tg>0 end
	local tc=nil
	if #tg==1 then
		tc=tg:GetFirst()
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		tc=tg:Select(tp,1,1,nil):GetFirst()
	end
	Duel.SetTargetCard(tc)
	local ctrl_player=tc:GetControler()
	local top_card=Duel.GetDecktopGroup(ctrl_player,1):GetFirst()
	local convulsion=Duel.IsPlayerAffectedByEffect(ctrl_player,EFFECT_REVERSE_DECK)
	local dg=Duel.GetMatchingGroup(s.publicfilter,ctrl_player,LOCATION_HAND|LOCATION_DECK,0,nil,convulsion,top_card,tc:GetCode())
	if #dg>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,#dg,tp,0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,ctrl_player,LOCATION_HAND|LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	local g=Duel.GetMatchingGroup(Card.IsCode,tc:GetControler(),LOCATION_HAND|LOCATION_DECK,0,nil,tc:GetCode())
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
