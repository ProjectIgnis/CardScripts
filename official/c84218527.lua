--フォーチュンレディ・リワインド
--Fortune Lady Rewind
--scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x31}
function s.filter(c,e,tp)
	return c:IsSetCard(0x31) and c:IsFaceup()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCanBeEffectTarget(e)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_REMOVED,0,nil,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,1,ft,aux.dncheck,0) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=aux.SelectUnselectGroup(g,e,tp,1,ft,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,#tg,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		local fid=e:GetHandler():GetFieldID()
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		end
		Duel.SpecialSummonComplete()
		g:KeepAlive()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCategory(CATEGORY_TODECK)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(g)
		e1:SetCondition(s.tdcon)
		e1:SetOperation(s.tdop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.tdfilter(c,fid)
	return c:GetFlagEffectLabel(id)==fid
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.tdfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.tdfilter,nil,e:GetLabel())
	Duel.SendtoDeck(tg,nil,2,REASON_EFFECT)
end
