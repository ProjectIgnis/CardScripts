--道化の一座 ホワイトフェイス
--Clown Crew Biancaviso
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--You can Tribute Summon this card face-up by Tributing 1 Ritual, Fusion, Synchro, Xyz, Pendulum, or Link Monster
	local e0=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.tributefilter)
	--If this card is Tribute Summoned: You can activate 1 of these effects (but you can only use each of these effects of "Clown Crew Biancaviso" once per turn)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(function(e) return c:IsTributeSummoned() end)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--Once per turn, during your opponent's Main Phase, you can (Quick Effect): Immediately after this effect resolves, Tribute Summon 1 monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SUMMON+CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return Duel.IsMainPhase(1-tp) end)
	e2:SetTarget(s.tribsumtg)
	e2:SetOperation(s.tribsumop)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
end
function s.tributefilter(c,tp)
	return c:IsType(TYPE_RITUAL|TYPE_PENDULUM|TYPE_EXTRA) and (c:IsControler(tp) or c:IsFaceup())
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetMaterialCount()
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsPlayerCanDraw(tp,ct)
	local b2=not Duel.HasFlagEffect(tp,id+1)
		and Duel.IsExistingMatchingCard(Card.IsNegatable,tp,0,LOCATION_ONFIELD,ct,nil)
	if chk==0 then return ct>0 and (b1 or b2) end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,3)},
		{b2,aux.Stringid(id,4)})
	e:SetLabel(op,ct)
	if op==1 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
	elseif op==2 then
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_DISABLE)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,ct,1-tp,LOCATION_ONFIELD)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op,ct=e:GetLabel()
	if op==1 then
		--● Draw cards equal to the number of monsters Tributed for its Tribute Summon
		Duel.Draw(tp,ct,REASON_EFFECT)
	elseif op==2 then
		--● Negate the effects of face-up cards your opponent controls, equal to the number of monsters Tributed for its Tribute Summon
		local g=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)
		if #g>=ct then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
			g=g:Select(tp,ct,ct,nil)
			Duel.HintSelection(g)
			local c=e:GetHandler()
			for sc in g:Iter() do
				--Negate their effects
				sc:NegateEffects(c,nil,true)
			end
		end
	end
end
function s.tribsumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.CanSummonOrSet,tp,LOCATION_HAND,0,1,nil,true,nil,1) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.tribsumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local sc=Duel.SelectMatchingCard(tp,Card.CanSummonOrSet,tp,LOCATION_HAND,0,1,1,nil,true,nil,1):GetFirst()
	if sc then
		Duel.SummonOrSet(tp,sc,true,nil,1)
	end
end