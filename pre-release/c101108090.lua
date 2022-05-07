--
--Libromancer Displaced
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Return 1 "libromancer" to the hand and take control of opponent's monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E+TIMING_MAIN_END)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x17d}
function s.tgfilter(c,e,tp)
	return (c:IsFaceup() and c:IsSetCard(0x17d) and c:IsControler(tp)) or (c:IsControler(1-tp) and c:IsControlerCanBeChanged())
		and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp,mg)
	local rg=sg:Filter(Card.IsControler,nil,tp)
    return #rg==1 and Duel.GetMZoneCount(tp,rg)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local rg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e,tp)
	if chk==0 then return aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(rg,e,tp,2,2,s.rescon,1,tp,HINTMSG_TARGET)
	Duel.SetTargetCard(tg)
	local hg=tg:Filter(Card.IsControler,nil,tp)
	e:SetLabelObject(hg:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,hg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tg:Filter(Card.IsControler,nil,1-tp),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g==0 then return end
	local tg1=g:GetFirst()
	local tg2=g:GetNext()
	if tg2==e:GetLabelObject() then tg1,tg2=tg2,tg1 end
	if tg1:IsControler(tp) and Duel.SendtoHand(tg1,nil,REASON_EFFECT)>0 and tg1:IsLocation(LOCATION_HAND)
		and tg2:IsControler(1-tp) then
		Duel.GetControl(tg2,tp)
		if not tg1:IsRitualMonster() then
			local c=e:GetHandler()
			local fid=c:GetFieldID()
			tg2:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
			--Return it to the hand during the End Phase
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetLabel(fid)
			e1:SetLabelObject(tg2)
			e1:SetCondition(s.thcon)
			e1:SetOperation(s.thop)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end