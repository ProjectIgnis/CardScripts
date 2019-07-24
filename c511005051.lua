--Phantom Scales
--  By Shad3

local scard=s

function scard.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(scard.tg)
	e1:SetOperation(scard.op)
	c:RegisterEffect(e1)
end

function scard.sel_fil(c,e)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsCanBeEffectTarget(e)
end

function scard.sum_fil(c,e,p,co)
	return c:IsCode(co) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function scard.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsFaceup() and chkc:IsOnField() end
	local g=Duel.GetMatchingGroup(scard.sel_fil,tp,LOCATION_MZONE,0,nil,e)
	local tg=g:Clone()
	local c=g:GetFirst()
	while c do
		if Duel.GetMatchingGroupCount(scard.sum_fil,tp,LOCATION_DECK,0,nil,e,tp,c:GetCode())==0 then
			tg:RemoveCard(c)
		end
		c=g:GetNext()
	end
	if chk==0 then return #tg>0 end
	local tc=tg:Select(tp,1,1,nil)
	Duel.SetTargetCard(tc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,tp,0)
end

function scard.op(e,tp,eg,ep,ev,re,r,rp)
  local tc=Duel.GetFirstTarget()
  if tc:IsRelateToEffect(e) then
    local ttc=Duel.SelectMatchingCard(tp,scard.sum_fil,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode()):GetFirst()
    if ttc then
      Duel.SpecialSummon(ttc,0,tp,tp,false,false,POS_FACEUP)
    end
  end
end