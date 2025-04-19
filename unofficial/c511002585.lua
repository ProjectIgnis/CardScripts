--リバイバル・チケット
--Revival Ticket
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon monsters you control destroyed by battle from the GYs
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Battle Damage register
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_DAMAGE)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		aux.AddValuesReset(function()
			s[0]=0
			s[1]=0
		end)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then
		s[tp]=s[tp]+ev
	end
	if ep==1-tp then
		s[1-tp]=s[1-tp]+ev
	end
end
function s.cfilter(c,tp,tid)
	return c:IsPreviousControler(tp) and c:IsMonster() and c:GetTurnID()==tid and c:GetReason()&REASON_BATTLE~=0
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    	return eg:IsExists(s.cfilter,1,nil,tp,Duel.GetTurnCount())
end
function s.ftchk(ft,tp,ct,e)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,e:GetHandler())
	if ft<=ct then
		ft=ft+g:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)
	end
end
function s.chkfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLocation(LOCATION_GRAVE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,tp,Duel.GetTurnCount())
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=#g
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	s.ftchk(ft,tp,ct,e)
	if chk==0 then return ct>0 and ft>=ct and g:FilterCount(s.chkfilter,nil,e,tp)==#g
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,0,ct,e:GetHandler()) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,ct,0,0)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,s[tp])
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,tp,Duel.GetTurnCount())
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=#g
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	s.ftchk(ft,tp,ct,e)
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,0,e:GetHandler())
	if ft<ct or g:FilterCount(s.chkfilter,nil,e,tp)~=#g then return end
	ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local dg=Group.CreateGroup()
	for i=1,ct do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		if ft<=0 then
			tc=sg:FilterSelect(tp,Card.IsLocation,1,1,nil,LOCATION_MZONE):GetFirst()
		else
			tc=sg:Select(tp,1,1,nil):GetFirst()
		end
		dg:AddCard(tc)
		sg:RemoveCard(tc)
		ft=ft+1
	end
	Duel.HintSelection(dg)
	Duel.Destroy(dg,REASON_EFFECT)
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	Duel.BreakEffect()
	Duel.Recover(tp,s[tp],REASON_EFFECT)
end