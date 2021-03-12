--魔鍵－マフテア
--Magikey - Maphteah
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Fusion
	local e1=Fusion.CreateSummonEff({handler=c,desc=aux.Stringid(id,0),fusfilter=aux.FilterBoolFunction(Card.IsSetCard,0x262),extrafil=s.fextra})
	c:RegisterEffect(e1)
	--Ritual
	local e2=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,desc=aux.Stringid(id,1),filter=aux.FilterBoolFunction(Card.IsSetCard,0x262),extrafil=s.rextra,extraop=s.extraop,forcedselection=s.rcheck})
	c:RegisterEffect(e2)
end
s.listed_series={0x262}
function s.costhint(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.fextra(e,tp,mg)
	if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsType,TYPE_NORMAL),tp,LOCATION_MZONE,0,1,nil) then
		local sg=Duel.GetMatchingGroup(s.fexfilter,tp,LOCATION_DECK,0,nil)
		if #sg>0 then
			return sg,s.fcheck
		end
	end
	return nil
end
function s.fexfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToGrave()
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.rcheck(e,tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
end
function s.rextra(e,tp,mg)
	if Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsType,TYPE_NORMAL),tp,LOCATION_MZONE,0,1,nil) then
		local sg=Duel.GetMatchingGroup(s.fexfilter,tp,LOCATION_DECK,0,nil)
		if #sg>0 then
			return sg
		end
	end
	return nil
end
function s.extraop(mg,e,tp,eg,ep,ev,re,r,rp)
	local mat2=mg:Filter(Card.IsLocation,nil,LOCATION_DECK)
	mg:Sub(mat2)
	Duel.ReleaseRitualMaterial(mg)
	Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
end