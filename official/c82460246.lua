--伍世壊＝カラリウム
--Primal Planet Kalarium
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate and add 1 "Manadome" monster or "Visas Starfrost" to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Increase the ATK of LIGHT monsters you control by 100 per each Tuner
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT))
	e2:SetValue(s.atkvalue)
	c:RegisterEffect(e2)
	--Special Summon 1 destroyed monster
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,1))
	e3a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3a:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3a:SetCode(EVENT_CUSTOM+id)
	e3a:SetRange(LOCATION_FZONE)
	e3a:SetCountLimit(1,id)
	e3a:SetTarget(s.sptg)
	e3a:SetOperation(s.spop)
	c:RegisterEffect(e3a)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e3a:SetLabelObject(g)
	--Register the destuction of monsters
	local e3b=Effect.CreateEffect(c)
	e3b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3b:SetCode(EVENT_DESTROYED)
	e3b:SetRange(LOCATION_FZONE)
	e3b:SetLabelObject(e3a)
	e3b:SetOperation(s.regop)
	c:RegisterEffect(e3b)
end
s.listed_names={CARD_VISAS_STARFROST}
s.listed_series={SET_MANADOME}
function s.thfilter(c)
	return ((c:IsMonster() and c:IsSetCard(SET_MANADOME)) or c:IsCode(CARD_VISAS_STARFROST)) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.atkvalue(e)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsType,TYPE_TUNER),e:GetHandlerPlayer(),LOCATION_MZONE|LOCATION_GRAVE,0,nil)*100
end
function s.tgfilter(c,tp,e)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and c:IsFaceup()
		and c:GetPreviousTypeOnField()&TYPE_TUNER>0 and c:IsPreviousControler(tp)
		and c:IsReason(REASON_BATTLE|REASON_EFFECT) and c:IsCanBeEffectTarget(e)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():Filter(s.tgfilter,nil,tp,e)
	if chkc then return g:IsContains(chkc) and s.tgfilter(chkc,tp,e) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	local tc=nil
	if #g==1 then
		tc=g:GetFirst()
		Duel.SetTargetCard(tc)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		tc=g:Select(tp,1,1,nil)
		Duel.SetTargetCard(tc)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>0 then return end
	local tg=eg:Filter(s.tgfilter,nil,tp,e)
	if #tg>0 then
		for tc in tg:Iter() do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		local g=e:GetLabelObject():GetLabelObject()
		if Duel.GetCurrentChain()==0 then g:Clear() end
		g:Merge(tg)
		g:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
		e:GetLabelObject():SetLabelObject(g)
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end