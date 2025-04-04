--幻影融合
--Vision Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon 1 "HERO" Fusion Monster from your Extra Deck, using monsters from your hand or field as Fusion Material
	local e1=Fusion.CreateSummonEff({handler=c,fusfilter=function(c) return c:IsSetCard(SET_HERO) end,extrafil=s.fextra,extraop=s.extraop,extratg=s.extratg})
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={SET_HERO}
function s.fextrafilter(c)
	return c:IsMonsterCard() and c:IsContinuousTrap() and c:IsAbleToRemove() and c:IsLocation(LOCATION_STZONE)
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(s.fextrafilter,nil)<=2
end
function s.fextra(e,tp,mg)
	local sg=Duel.GetMatchingGroup(s.fextrafilter,tp,LOCATION_STZONE,0,nil)
	if #sg>0 then
		return sg,s.fcheck
	end
	return nil
end
function s.extraop(e,tc,tp,sg)
	local rg=sg:Filter(s.fextrafilter,nil)
	if #rg>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
		sg:Sub(rg)
	end
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_STZONE)
end
